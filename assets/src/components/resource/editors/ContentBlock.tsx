import React, { PropsWithChildren } from 'react';
import { DeleteButton } from 'components/misc/DeleteButton';
import { ResourceContent, StructuredContent } from 'data/content/resource';
import * as Immutable from 'immutable';
import { classNames } from 'utils/classNames';
import styles from './ContentBlock.modules.scss';

interface ContentBlockProps {
  editMode: boolean;
  content: Immutable.List<ResourceContent>;
  contentItem: StructuredContent;
  canRemove: boolean;
  onRemove: (key: string) => void;
}

export const ContentBlock = (props: PropsWithChildren<ContentBlockProps>) => {
  return (
    <div
      id={`resource-editor-${props.contentItem.id}`}
      className={classNames(
        styles.contentBlock,
        'content-block',
        `purpose-${props.contentItem.purpose}`,
      )}
    >
      <div className={styles.actions}>
        <DeleteButton
          editMode={props.editMode && props.canRemove}
          onClick={() => props.onRemove(props.contentItem.id)}
        />
      </div>
      <div>{props.children}</div>
    </div>
  );
};
